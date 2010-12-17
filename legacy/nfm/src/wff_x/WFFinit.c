#include "machine.h"
#include "WFF.h"

/*  Global WFF structure  */

extern struct WFFglobal_st WFFglobal;

void _WFFinit_global ()
  {
	WFFglobal.bar_menu_height = BAR_MENU_HEIGHT;

	WFFglobal.playback_time = -1;
	WFFglobal.delay_time = -1;
	WFFglobal.time_value = 0;
	WFFglobal.timestamp_enabled = FALSE;
	strcpy (WFFglobal.record_file, "");
	strcpy (WFFglobal.playback_file, "");
	strcpy (WFFglobal.timestamp_file, "");
	strcpy (WFFglobal.timestamp_buffer, "");

	WFFglobal.button_transition = SINGLE_CLICK;

	strcpy (WFFglobal.server, "");
	strcpy (WFFglobal.username, "");
	strcpy (WFFglobal.password, "");
	strcpy (WFFglobal.environment, "");
	strcpy (WFFglobal.workflow, "");
	strcpy (WFFglobal.acl, "");
        strcpy (WFFglobal.display_name, "" );
	WFFglobal.user_id = 0;

	/*  Initialize default WFF debug file  */

	strcpy (WFFglobal.debug_file, "/dev/console");
	WFFglobal.debug_on = 0;

	strcpy (WFFglobal.keyboard_buffer, "");
	WFFglobal.cmd_status = NFI_S_SUCCESS;
	WFFglobal.error_no = NFI_S_SUCCESS;
	WFFglobal.working_no = NFI_S_CLEAR_MSG;
	WFFglobal.current_list = NULL;
	WFFglobal.current_popup = NULL;
	WFFglobal.no_scrl_cols = 0;
	WFFglobal.scrl_val = 0;

	/*  Initialize array of pointers to NFMR functions  */
#ifndef XWINDOWS
	WFFglobal.NFMfunction[0] = NULL;
	WFFglobal.NFMfunction[1] = NULL;
	WFFglobal.NFMfunction[2] = NULL;
#endif
	/*  Initialize form pointers  */

	WFFglobal.message_form = NULL;
	WFFglobal.main_form = NULL;
	WFFglobal.current_form = NULL;

	WFFglobal.tx_mcf = 0;
	WFFglobal.ty_mcf = 0;
	WFFglobal.x_mcf  = 0;
	WFFglobal.y_mcf  = 0;

	WFFglobal.x_scrl   = 0;
	WFFglobal.y_scrl   = 0;
	WFFglobal.g_height = 0;
	WFFglobal.g_width  = 0;

	/*  Initialize flag to call FI_process_forms ()  */

	WFFglobal.call_process_forms = TRUE;
        WFFglobal.Help_initialized = FALSE;
	WFFglobal.where_message_is = NULL;
	WFFglobal.numslots = 0;
        
	/*  Initialize listing buffers  */

	WFFglobal.attr_list = NULL;
	WFFglobal.list_buffer = NULL;

	/*  Initialize local copy of server debug settings  */

	WFFglobal.WFFserver.flag1 = FALSE;   /* WFF */
	WFFglobal.WFFserver.flag2 = FALSE;   /* NFM */
	WFFglobal.WFFserver.flag3 = FALSE;   /* SQL */
	WFFglobal.WFFserver.flag4 = FALSE;   /* MEM */
	WFFglobal.WFFserver.flag5 = FALSE;   /* ERR */
	strcpy (WFFglobal.WFFserver.file1, "/dev/console");
	strcpy (WFFglobal.WFFserver.file2, "/dev/console");
	strcpy (WFFglobal.WFFserver.file3, "/dev/console");
	strcpy (WFFglobal.WFFserver.file4, "/dev/console");
	strcpy (WFFglobal.WFFserver.file5, "/dev/console");

	WFFglobal.confirmed = 0;
        WFFglobal.copy_wf   = 0;

	return;
  }


long _WFFinit_graphics (program_name)
  char	*program_name;
  {
    int		status;

    static	char *fname = "_WFFinit_graphics";

#ifdef XWINDOWS
    auto    char *display_name;

    /*  If 'display' was not on the command line, check the environment
     *  variable.
     */

    if( strcmp( WFFglobal.display_name, "" ) == 0 )
    {
      if ((display_name = (char *) getenv ("DISPLAY")) == NULL)
        {
          _NFIdebug ((fname, "getenv failed for DISPLAY name\n"));
	  /* Default display to <:0.0> */
	  display_name = (char*)malloc(5);
	  strcpy( display_name, ":0.0" );
        }
 	strcpy( WFFglobal.display_name, display_name );
    }

    if ((WFFglobal.display = XOpenDisplay (WFFglobal.display_name)) == None)
      {
        _NFIdebug ((fname, "XOpenDisplay = <%d>\n", WFFglobal.display));
        ERRload_struct (NFI, NFI_E_GRAPHICS, "%s%d", "XOpenDisplay", 
		        WFFglobal.display);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_GRAPHICS);
      }

    FSEnter (WFFglobal.display, 0);

    FI_enter (WFFglobal.display, DefaultColormap (WFFglobal.display,
	      DefaultScreen (WFFglobal.display)), 32);

    /*  Override FEI_process_data () with _WFFprocess_data ()  */

    if ((status = FI_modify_env(FI_PROCESS_DATA,_WFFprocess_data))!=FI_SUCCESS)
      {
        _NFIdebug ((fname, "FI_modify_env = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FI_modify_env", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Find the I/NFM configuration  */

    if ((status = _WFFsetup_config (program_name)) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_WFFsetup_config = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    if ((status = MS_enter ()) != MS_SUCCESS)
      {
        _NFIdebug ((fname, "MS_enter = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_MENU, "%s%d", "MS_enter", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_MENU);
      }

    if ((status = FI_set_select_button(Button1)))
      {
        _NFIdebug ((fname, "FI_set_select_button = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FI_set_select_button", 
		status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }
#else

    if (status = Enter_tools ())
    {
	_NFIdebug ((fname, "Enter_tools = <%d>\n", status));
	ERRload_struct (NFI, NFI_E_GRAPHICS, "%s%d", "Enter_tools", status);
	_NFIdebug ((fname, " returning FAILURE\n"));
	return (NFI_E_GRAPHICS);
    }

    if (status = Enable_events (FI_EVENT_MASK))
    {
	_NFIdebug ((fname, "Enable_events = <%d>\n", status));
	ERRload_struct (NFI, NFI_E_GRAPHICS, "%s%d", "Enable_events", status);
	_NFIdebug ((fname, " returning FAILURE\n"));
	return (NFI_E_GRAPHICS);
    }

    status = FI_enter ();
    if( status != FI_SUCCESS )
    {
	_NFIdebug ((fname, "FI_enter = <%d>\n", status));
	ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FI_enter", status);
	_NFIdebug ((fname, " returning FAILURE\n"));
	return (NFI_E_FORM);
    }

/*  Override FEI_process_data () with _WFFprocess_data ()  */

    status = FI_modify_env(FI_PROCESS_DATA, _WFFprocess_data);
    if( status != FI_SUCCESS )
    {
	_NFIdebug ((fname, "FI_modify_env = <%d>\n", status));
	ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FI_modify_env", status);
	_NFIdebug ((fname, " returning FAILURE\n"));
	return (NFI_E_FORM);
    }

/*  Find the I/NFM configuration  */

    status = _WFFsetup_config(program_name);
    if( status != NFI_S_SUCCESS )
    {
 	_NFIdebug ((fname, "_WFFsetup_config = <0x%.8x>\n", status));
	_NFIdebug ((fname, " returning FAILURE\n"));
	return (status);
    }

/*  Setup a standard vlt  */

    status = _WFFsetup_vlt ();
    if (status == NFI_S_SUCCESS)
    {
       /* Override FEI_translate_color () with _WFFtranslate_color () */
        status = FI_modify_env(FI_TRANSLATE_COLOR, _WFFtranslate_color);
 	if( status != FI_SUCCESS)
        {
  	    _NFIdebug ((fname, "FI_modify_env = <%d>\n", status));
	    ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FI_modify_env", status);
	    _NFIdebug ((fname, " returning FAILURE\n"));
	    return (NFI_E_FORM);
        }
    }
    else if (status != NFI_I_FIXED_VLT)
    {
	_NFIdebug ((fname, "_WFFsetup_vlt = <0x%.8x>\n", status));
	_NFIdebug ((fname, " returning FAILURE\n"));
	return (status);
    }

    status = MS_enter ();
    if( status != MS_SUCCESS )
    {
	_NFIdebug ((fname, "MS_enter = <%d>\n", status));
	ERRload_struct (NFI, NFI_E_MENU, "%s%d", "MS_enter", status);
	_NFIdebug ((fname, " returning FAILURE\n"));
	return (NFI_E_MENU);
    }

/*  Initialize journaling  */

/*
    if ((strcmp (WFFglobal.record_file, "")) != 0)
    {
	if ((status = JNL_init_journal (WFFglobal.record_file, 0)) != 1)
	{
  	    _NFIdebug ((fname, "JNL_init_journal = <%d>\n", status));
	    ERRload_struct(NFI, NFI_E_JOURNAL, "%s%d", "JNL_init_journal", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
  	    return (NFI_E_JOURNAL);
        }
    }

    if ((strcmp (WFFglobal.playback_file, "")) != 0)
    {
	if ((status = JNL_init_playback (WFFglobal.playback_file)) != 1)
        {
 	    _NFIdebug ((fname, "JNL_init_playback = <%d>\n", status));
	    ERRload_struct(NFI, NFI_E_JOURNAL, "%s%d", "JNL_init_playback", status);
	    _NFIdebug ((fname, " returning FAILURE\n"));
	    return (NFI_E_JOURNAL);
        }

	status = JNL_set_timer_playback (WFFglobal.playback_time);
	if( status != 1)
        {
  	    _NFIdebug ((fname, "JNL_set_timer_playback = <%d>\n", status));
            ERRload_struct(NFI, NFI_E_JOURNAL, "%s%d", "JNL_set_timer_playback", status);
	    _NFIdebug ((fname, " returning FAILURE\n"));
	    return (NFI_E_JOURNAL);
        }
    }

    status = FI_set_keyboard_buffer (WFFglobal.keyboard_buffer,
		sizeof (WFFglobal.keyboard_buffer));
    if( status != FI_SUCCESS)
    {
	_NFIdebug ((fname, "FI_set_keyboard_buffer = <%d>\n", status));
	ERRload_struct(NFI, NFI_E_JOURNAL, "%s%d", "FI_set_keyboard_buffer", status);
	_NFIdebug ((fname, " returning FAILURE\n"));
	return (NFI_E_JOURNAL);
    }

    if (status = JNL_set_keyboard_buffer
		(WFFglobal.keyboard_buffer, sizeof (WFFglobal.keyboard_buffer)))
    {
	_NFIdebug ((fname, "JNL_set_keyboard_buffer = <%d>\n", status));
	ERRload_struct(NFI, NFI_E_JOURNAL, "%s%d", "JNL_set_keyboard_buffer", status);
	_NFIdebug ((fname, " returning FAILURE\n"));
	return (NFI_E_JOURNAL);
    }
*/

    status = FI_enter ();
    if( status != FI_SUCCESS)
    {
	_NFIdebug ((fname, "FI_enter = <%d>\n", status));
	ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FI_enter", status);
	_NFIdebug ((fname, " returning FAILURE\n"));
	return (NFI_E_FORM);
    }

#endif

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
}
