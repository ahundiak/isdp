
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"
#include <FEI.h>

/*  Global structure  */

extern struct NFFglobal_st NFFglobal;

void _NFFinit_global ()
  {
    auto  int  i;

    for (i = 0; i < 4; ++i)
        NFFglobal.locations[i] = 0;
    for (i = 0; i < NUMBER_OF_FORMS; ++i)
      {
        NFFglobal.positions[i] = -1;
        NFFglobal.forms[i] = NULL;
      }

    NFFglobal.scale_factor_x = 1.0;
    NFFglobal.scale_factor_y = 1.0;

#ifndef XWINDOWS
    NFFglobal.NFMRfunction[0] = NULL;
    NFFglobal.NFMRfunction[1] = NULL;
    NFFglobal.NFMRfunction[2] = NULL;
#endif
    NFFglobal.status = NFI_S_SUCCESS;
    NFFglobal.working_no = NULL;
    NFFglobal.project_active = FALSE;
    NFFglobal.search_active = FALSE;
    NFFglobal.sort_active = FALSE;
    NFFglobal.current_form = NULL;
    NFFglobal.popup_form = NULL;
    NFFglobal.debug_form = NULL;
    NFFglobal.error_form = NULL;
    NFFglobal.add_util_sa_form = NULL;
    NFFglobal.where_message_is = MAIN_LABEL;
    NFFglobal.timestamp_enabled = FALSE;
    NFFglobal.delay_time = -1;
    NFFglobal.playback_time = -1;
    NFFglobal.collapse_flag = FALSE;
    strcpy (NFFglobal.playback_file, "");
    strcpy (NFFglobal.record_file, "");
    strcpy (NFFglobal.timestamp_file, "");

    strcpy (NFFglobal.server, "");
    strcpy (NFFglobal.username, "");
    strcpy (NFFglobal.password, "");
    strcpy (NFFglobal.environment, "");
    strcpy (NFFglobal.storage_area, "");
    strcpy (NFFglobal.user, "");
    strcpy (NFFglobal.catalog, "");
    strcpy (NFFglobal.class, "");
    strcpy (NFFglobal.project, "");
    strcpy (NFFglobal.workflow, "");
    strcpy (NFFglobal.acl, "");
    strcpy (NFFglobal.item, "");
    strcpy (NFFglobal.new_item, "" );
    strcpy (NFFglobal.revision, "");
    strcpy (NFFglobal.new_revision, "" );
    strcpy (NFFglobal.set_indicator, "");
    strcpy (NFFglobal.search, "");
    strcpy (NFFglobal.sort, "");
    strcpy (NFFglobal.display_name, "" );
    return;
  }


long _NFFinit_graphics ()
  {
    auto    int  status;
    static  char *fname = "_NFFinit_graphics";

#ifdef XWINDOWS
    auto    char *display_name;

#define     DEFAULT_DISPLAY   ":0.0"

    /*  If 'display' was not on the command line, check the environment
     *  variable.
     */

    if( strcmp( NFFglobal.display_name, "" ) == 0 )
    {
      if ((display_name = (char *) getenv ("DISPLAY")) == NULL)
        {
          _NFIdebug ((fname, "getenv failed for DISPLAY name\n"));

	  /*  Default the display  */

	  if ((display_name =
	      (char *) malloc (strlen (DEFAULT_DISPLAY) + 1)) == NULL)
            {
	      _NFIdebug ((fname, "malloc failed; size = <%d>\n",
		  strlen (DEFAULT_DISPLAY + 1)));
              ERRload_struct (NFI, NFI_E_MALLOC, "%d",
		  strlen (DEFAULT_DISPLAY + 1));
	      _NFIdebug ((fname, "returning FAILURE\n"));
	      return (NFI_E_MALLOC);
	    }

          strcpy (display_name, DEFAULT_DISPLAY);
        }

 	strcpy( NFFglobal.display_name, display_name );
    }

    _NFIdebug ((fname, "XOpenDisplay <%s>\n", NFFglobal.display_name ));
    if ((NFFglobal.display = XOpenDisplay (NFFglobal.display_name)) == None)
      {
        _NFIdebug ((fname, "XOpenDisplay = <%d>\n", NFFglobal.display));
        ERRload_struct (NFI, NFI_E_GRAPHICS, "%s%d", "XOpenDisplay", 
		        NFFglobal.display);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_GRAPHICS);
      }

    FSEnter (NFFglobal.display, 0);

    FI_enter (NFFglobal.display, DefaultColormap (NFFglobal.display,
	      DefaultScreen (NFFglobal.display)), 32);

    /*  Override FEI_process_data () with _NFIprocess_data ()  */

    if ((status = FI_modify_env
        (FI_PROCESS_DATA, _NFFprocess_data)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FI_modify_env = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FI_modify_env", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Find the I/NFM configuration  */

    if ((status = _NFFsetup_config ()) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFsetup_config = <0x%.8x>\n", status));
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

    if ((status = FEI_enter ()) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FEI_enter = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_JOURNAL, "%s%d", "FEI_enter", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_JOURNAL);
      }

    /*  Set select button to be the LEFT_BUTTON which is X standard. */

    if ((status = FI_set_select_button (Button1)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FI_set_select_button = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FI_set_select_button", 
			status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Set the form auto scale factor based upon the
        remote X display and the size of the Environ V
        display that the forms were originally created on - Glenn  */


    NFFglobal.scale_factor_x = ((double) DisplayWidth (NFFglobal.display,
        DefaultScreen (NFFglobal.display)) / (double) MAX_SCREEN_WIDTH);
    NFFglobal.scale_factor_y = ((double) DisplayHeight (NFFglobal.display,
        DefaultScreen (NFFglobal.display)) / (double) MAX_SCREEN_HEIGHT);

    _NFIdebug ((fname, "scale_factor_x = %f\n", NFFglobal.scale_factor_x));
    _NFIdebug ((fname, "scale_factor_y = %f\n", NFFglobal.scale_factor_y));

    if ((status = FI_set_auto_scaling_factors
        (NFFglobal.scale_factor_x, NFFglobal.scale_factor_y)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FI_set_auto_scaling_factors = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d",
            "FI_set_auto_scaling_factors", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }
/* PS */
    _NFIdebug ((fname, "auto_scale_factor_x = %f\n", NFFglobal.scale_factor_x));
    _NFIdebug ((fname, "auto_scale_factor_y = %f\n", NFFglobal.scale_factor_y));

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

    if ((status = FI_enter ()) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FI_enter = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FI_enter", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Override FEI_process_data () with _NFIprocess_data ()  */

    if ((status = FI_modify_env
        (FI_PROCESS_DATA, _NFFprocess_data)) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FI_modify_env = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FI_modify_env", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_FORM);
      }

    /*  Find the I/NFM configuration  */

    if ((status = _NFFsetup_config ()) != NFI_S_SUCCESS)
      {
        _NFIdebug ((fname, "_NFFsetup_config = <0x%.8x>\n", status));
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (status);
      }

    /*  Setup a standard vlt  */

    status = _NFFsetup_vlt ();
    if (status == NFI_S_SUCCESS)
      {
        /*  Override FEI_translate_color () with _NFItranslate_color ()  */

        if ((status = FI_modify_env
            (FI_TRANSLATE_COLOR, _NFFtranslate_color)) != FI_SUCCESS)
          {
            _NFIdebug ((fname, "FI_modify_env = <%d>\n", status));
            ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FI_modify_env", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_FORM);
          }
      }
    else if (status != NFI_I_FIXED_VLT)
      {
        _NFIdebug ((fname, "_NFFsetup_vlt = <0x%.8x>\n", status));
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

    /*  Initialize journaling  */

    if ((strcmp (NFFglobal.record_file, "")) != 0)
      {
        if ((status = JNL_init_journal (NFFglobal.record_file, 0)) != 1)
          {
            _NFIdebug ((fname, "JNL_init_journal = <%d>\n", status));
            ERRload_struct
                (NFI, NFI_E_JOURNAL, "%s%d", "JNL_init_journal", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_JOURNAL);
          }
      }

    if ((strcmp (NFFglobal.playback_file, "")) != 0)
      {
        if ((status = JNL_init_playback (NFFglobal.playback_file)) != 1)
          {
            _NFIdebug ((fname, "JNL_init_playback = <%d>\n", status));
            ERRload_struct
                (NFI, NFI_E_JOURNAL, "%s%d", "JNL_init_playback", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_JOURNAL);
          }

        if ((status = JNL_set_timer_playback (NFFglobal.playback_time)) != 1)
          {
            _NFIdebug ((fname, "JNL_set_timer_playback = <%d>\n", status));
            ERRload_struct
                (NFI, NFI_E_JOURNAL, "%s%d", "JNL_set_timer_playback", status);
            _NFIdebug ((fname, " returning FAILURE\n"));
            return (NFI_E_JOURNAL);
          }
      }

    if ((status = FI_set_keyboard_buffer (NFFglobal.keyboard_buffer,
        sizeof (NFFglobal.keyboard_buffer))) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FI_set_keyboard_buffer = <%d>\n", status));
        ERRload_struct
            (NFI, NFI_E_JOURNAL, "%s%d", "FI_set_keyboard_buffer", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_JOURNAL);
      }

    if (status = JNL_set_keyboard_buffer
        (NFFglobal.keyboard_buffer, sizeof (NFFglobal.keyboard_buffer)))
      {
        _NFIdebug ((fname, "JNL_set_keyboard_buffer = <%d>\n", status));
        ERRload_struct
            (NFI, NFI_E_JOURNAL, "%s%d", "JNL_set_keyboard_buffer", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_JOURNAL);
      }

    if ((status = FEI_enter ()) != FI_SUCCESS)
      {
        _NFIdebug ((fname, "FEI_enter = <%d>\n", status));
        ERRload_struct (NFI, NFI_E_JOURNAL, "%s%d", "FEI_enter", status);
        _NFIdebug ((fname, " returning FAILURE\n"));
        return (NFI_E_JOURNAL);
      }
#endif

    _NFIdebug ((fname, " returning SUCCESS\n"));
    return (NFI_S_SUCCESS);
  }
