/* Do not alter this SPC information: $Revision: 1.2.40.1 $ */
/*
**	NAME:							guipswd.c
**	AUTHORS:						Terrence McIntyre
**	CREATION DATE:					5/93
**	ABSTRACT:
**	
**	REVISION HISTORY:
**
**	11/94:	Added support for INTERNATIONALIZATION.  Rick Kramer
*/
 
/*
**	INCLUDES
*/
#include "rislimit.h"
#include "gui.h"

/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define guipswd_c
#include "fi.prt"
#include "event.prt"
#include "comdebug.prt"
#include "guierror.prt"
#include "guintfy.prt"
#include "guipswd.prt"
#include "guiutil.prt"
#include "guiin.prt"
#include "sys.prt"
#if defined(WIN32)
#include "fi_winnt.prt"
#endif

/*
**	VARIABLES
*/
static	Form	pw_form = 0;
static	int		exit_status;
static	char	password[RIS_MAX_ID_SIZE];

/*
**	FUNCTIONS
*/

/******************************************************************************/

static void clear_password_field()
{
	GUI_DBG(("clear_password_field()\n"));

	FIfld_set_text(pw_form, PW_PASSWORD_FIELD, 0, 0, "", 0);

	GUI_DBG(("clear_password_field:returning\n"));
}

/******************************************************************************/

static int pw_form_displayed()
{
	int	form_displayed = 0;

	GUI_DBG(("pw_form_displayed()\n"));

	if (pw_form)
	{
		FIf_is_displayed(pw_form, &form_displayed);
	}

	GUI_DBG(("pw_form_displayed: returning form_displayed:%d\n",
		form_displayed));
	return(form_displayed);
}

/******************************************************************************/

static void display_pw_form()
{
	int		sts;

	GUI_DBG(("display_pw_form()\n"));

	if (!pw_form)
	{
		sts = FIf_new(PW_FORM, PW_FORM_FILE, RISgui_notification_routine,
			&pw_form);
		if (sts)
		{
			RISgui_errhandle(RISUTL_E_CREATE_PW_FORM, sts);
			RISgui_report_error();
			GUI_DBG(("display_pw_form:returning\n"));
			return;
		}
		RISgui_center_form(pw_form);
	}

	if (!pw_form_displayed())
	{
		sts = FIf_display(pw_form);
		if (sts)
		{
			RISgui_errhandle(RISUTL_E_DISPLAY_PW_FORM, sts);
			RISgui_report_error();
			GUI_DBG(("display_pw_form:returning\n"));
			return;
		}
	}

	FIfld_pos_cursor(pw_form, PW_PASSWORD_FIELD, 0, 0, 0, 0, 0, 0);
	CLEAR_ERROR;

	GUI_DBG(("display_pw_form:returning\n"));
	return;
}

/******************************************************************************/

extern void erase_pw_form()
{
	int	sts;

	GUI_DBG(("erase_pw_form()\n"));

	if (pw_form_displayed())
	{
		sts = FIf_erase(pw_form);
		if (sts)
		{
			RISgui_errhandle(RISUTL_E_ERASE_PW_FORM, sts);
			RISgui_report_error();
			GUI_DBG(("erase_pw_form: returning\n"));
			return;
		}
	}

	clear_password_field();

	CLEAR_ERROR;

	GUI_DBG(("erase_pw_form: returning\n"));
	return;
}

/******************************************************************************/

static void process_accept_button()
{
	int sel_flag, r_pos;

	GUI_DBG(("process_accept_button()\n"));

	FIfld_get_text(pw_form, PW_PASSWORD_FIELD, 0, 0, RIS_MAX_ID_SIZE,
		(unsigned char *)password, &sel_flag, &r_pos);

	erase_pw_form();

	exit_status = 1;
	GUI_DBG(("process_accept_button:returning\n"));
}

/******************************************************************************/

static void process_cancel_button()
{
	GUI_DBG(("process_cancel_button()\n"));

	erase_pw_form();

	exit_status = 0;
	GUI_DBG(("process_cancel_button:returning\n"));
}

/******************************************************************************/

static void process_toggle()
{
	GUI_DBG(("process_toggle()\n"));

	RISgui_set_passwd_echo(pw_form, PW_PASSWORD_TOGGLE, PW_PASSWORD_FIELD);

	GUI_DBG(("process_toggle:returning\n"));
}

/******************************************************************************/

extern void RISgui_process_pw_form(
	int	g_label)
{
	int	i;
	static	ris_gui_label_function	process_gadget[] = 
	{
		{	FI_CANCEL,			process_cancel_button	},
		{	FI_ACCEPT,			process_accept_button	},
		{	PW_PASSWORD_TOGGLE,	process_toggle			},
	};
	static	int						process_gadget_count =
		sizeof(process_gadget)/sizeof(ris_gui_label_function);

	GUI_DBG(("RISgui_process_pw_form(g_label:%d)\n", g_label));

	for (i = 0; i < process_gadget_count; i++)
	{
		if (process_gadget[i].label == g_label)
		{
			(process_gadget[i].function_ptr)();
			break;
		}
	}

	GUI_DBG(("RISgui_process_pw_form:returning\n"));
}

/******************************************************************************/

extern int RISgui_get_password(
	char *ptr)
{
	GUI_DBG(("RISgui_get_password()\n"));

	exit_status = 0;

	display_pw_form();

	RISgui_event_loop(pw_form_displayed);

	if (exit_status)
	{
		strcpy(ptr, password);
	}

	GUI_DBG(("RISgui_get_password:returning exit_status:%d\n",
		exit_status));

	return exit_status;
}

/******************************************************************************/
