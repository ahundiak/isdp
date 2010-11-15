/* Do not alter this SPC information: $Revision: 1.2.40.1 $ */
/*
**	NAME:							guiuspw.c
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
#define guiuspw_c
#include "fi.prt"
#include "event.prt"
#include "comdebug.prt"
#include "guierror.prt"
#include "guintfy.prt"
#include "guiuspw.prt"
#include "guiutil.prt"
#include "guiin.prt"
#include "sys.prt"
#if defined(WIN32)
#include "fi_winnt.prt"
#endif

/*
**	VARIABLES
*/
static	Form	up_form = 0;
static	int		exit_status;
static	char	username[RIS_MAX_ID_SIZE];
static	char	password[RIS_MAX_ID_SIZE];

/*
**	FUNCTIONS
*/

/******************************************************************************/

static void clear_username_field()
{
	GUI_DBG(("clear_username_field()\n"));

	FIfld_set_text(up_form, UP_USERNAME_FIELD, 0, 0, "", 0);

	GUI_DBG(("clear_username_field:returning\n"));
}

/******************************************************************************/

static void clear_password_field()
{
	GUI_DBG(("clear_password_field()\n"));

	FIfld_set_text(up_form, UP_PASSWORD_FIELD, 0, 0, "", 0);

	GUI_DBG(("clear_password_field:returning\n"));
}

/******************************************************************************/

static int up_form_displayed()
{
	int	form_displayed = 0;

	GUI_DBG(("up_form_displayed()\n"));

	if (up_form)
	{
		FIf_is_displayed(up_form, &form_displayed);
	}

	GUI_DBG(("up_form_displayed: returning form_displayed:%d\n",
		form_displayed));
	return(form_displayed);
}

/******************************************************************************/

static void display_up_form()
{
	int		sts;

	GUI_DBG(("display_up_form()\n"));

	if (!up_form)
	{
		sts = FIf_new(UP_FORM, UP_FORM_FILE, RISgui_notification_routine,
			&up_form);
		if (sts)
		{
			RISgui_errhandle(RISUTL_E_CREATE_UP_FORM, sts);
			RISgui_report_error();
			GUI_DBG(("display_up_form:returning\n"));
			return;
		}
		RISgui_center_form(up_form);
	}

	if (!up_form_displayed())
	{
		sts = FIf_display(up_form);
		if (sts)
		{
			RISgui_errhandle(RISUTL_E_DISPLAY_UP_FORM, sts);
			RISgui_report_error();
			GUI_DBG(("display_up_form:returning\n"));
			return;
		}
	}

	FIfld_pos_cursor(up_form, UP_USERNAME_FIELD, 0, 0, 0, 0, 0, 0);
	CLEAR_ERROR;

	GUI_DBG(("display_up_form:returning\n"));
	return;
}

/******************************************************************************/

extern void erase_up_form()
{
	int	sts;

	GUI_DBG(("erase_up_form()\n"));

	if (up_form_displayed())
	{
		sts = FIf_erase(up_form);
		if (sts)
		{
			RISgui_errhandle(RISUTL_E_ERASE_UP_FORM, sts);
			RISgui_report_error();
			GUI_DBG(("erase_up_form: returning\n"));
			return;
		}
	}

	clear_username_field();
	clear_password_field();

	CLEAR_ERROR;

	GUI_DBG(("erase_up_form: returning\n"));
	return;
}

/******************************************************************************/

static void process_accept_button()
{
	int sel_flag, r_pos;

	GUI_DBG(("process_accept_button()\n"));

	FIfld_get_text(up_form, UP_USERNAME_FIELD, 0, 0, RIS_MAX_ID_SIZE,
		(unsigned char *)username, &sel_flag, &r_pos);
	FIfld_get_text(up_form, UP_PASSWORD_FIELD, 0, 0, RIS_MAX_ID_SIZE,
		(unsigned char *)password, &sel_flag, &r_pos);

	erase_up_form();

	exit_status = 1;
	GUI_DBG(("process_accept_button:returning\n"));
}

/******************************************************************************/

static void process_cancel_button()
{
	GUI_DBG(("process_cancel_button()\n"));

	erase_up_form();

	exit_status = 0;
	GUI_DBG(("process_cancel_button:returning\n"));
}

/******************************************************************************/

static void process_toggle()
{
	GUI_DBG(("process_toggle()\n"));

	RISgui_set_passwd_echo(up_form, UP_PASSWORD_TOGGLE, UP_PASSWORD_FIELD);

	GUI_DBG(("process_toggle:returning\n"));
}

/******************************************************************************/

extern void RISgui_process_up_form(
	int	g_label)
{
	int	i;
	static	ris_gui_label_function	process_gadget[] = 
	{
		{	FI_CANCEL,			process_cancel_button	},
		{	FI_ACCEPT,			process_accept_button	},
		{	UP_PASSWORD_TOGGLE,	process_toggle			},
	};
	static	int						process_gadget_count =
		sizeof(process_gadget)/sizeof(ris_gui_label_function);

	GUI_DBG(("RISgui_process_up_form(g_label:%d)\n", g_label));

	for (i = 0; i < process_gadget_count; i++)
	{
		if (process_gadget[i].label == g_label)
		{
			(process_gadget[i].function_ptr)();
			break;
		}
	}

	GUI_DBG(("RISgui_process_up_form:returning\n"));
}

/******************************************************************************/

extern int RISgui_get_username_password(
	char *uptr,
	char *pptr)
{
	GUI_DBG(("RISgui_get_username_password()\n"));

	exit_status = 0;

	display_up_form();

	RISgui_event_loop(up_form_displayed);

	if (exit_status)
	{
		strcpy(uptr, username);
		strcpy(pptr, password);
	}

	GUI_DBG(("RISgui_get_username_password:returning exit_status:%d\n",
		exit_status));

	return exit_status;
}

/******************************************************************************/
