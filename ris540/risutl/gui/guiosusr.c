/* Do not alter this SPC information: $Revision: 1.2.40.1 $ */
/*
**	NAME:							guiosusr.c
**	AUTHORS:						linda wang
**	CREATION DATE:					4/94
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
#define guiosusr_c
#include "fi.prt"
#include "event.prt"
#include "comdebug.prt"
#include "guierror.prt"
#include "guintfy.prt"
#include "guiosusr.prt"
#include "guiutil.prt"
#include "guiin.prt"
#include "sys.prt"
#if defined(WIN32)
#include "fi_winnt.prt"
#endif

/*
**	VARIABLES
*/
static	Form	os_form = 0;
static	int		exit_status;
static	char	username[RIS_MAX_ID_SIZE];
static	char	password[RIS_MAX_ID_SIZE];
static	char	osusername[RIS_MAX_ID_SIZE];
static	char	ospassword[RIS_MAX_ID_SIZE];

/*
**	FUNCTIONS
*/

/******************************************************************************/

static void clear_username_field()
{
	GUI_DBG(("clear_username_field()\n"));

	FIfld_set_text(os_form, OS_USERNAME_FIELD, 0, 0, "", 0);

	GUI_DBG(("clear_username_field:returning\n"));
}

/******************************************************************************/

static void clear_password_field()
{
	GUI_DBG(("clear_password_field()\n"));

	FIfld_set_text(os_form, OS_PASSWORD_FIELD, 0, 0, "", 0);

	GUI_DBG(("clear_password_field:returning\n"));
}

/******************************************************************************/

static void clear_osusername_field()
{
	GUI_DBG(("clear_osusername_field()\n"));

	FIfld_set_text(os_form, OS_OS_USERNAME_FIELD, 0, 0, "", 0);

	GUI_DBG(("clear_osusername_field:returning\n"));
}

/******************************************************************************/

static void clear_ospassword_field()
{
	GUI_DBG(("clear_ospassword_field()\n"));

	FIfld_set_text(os_form, OS_OS_PASSWORD_FIELD, 0, 0, "", 0);

	GUI_DBG(("clear_ospassword_field:returning\n"));
}

/******************************************************************************/

static int os_form_displayed()
{
	int	form_displayed = 0;

	GUI_DBG(("os_form_displayed()\n"));

	if (os_form)
	{
		FIf_is_displayed(os_form, &form_displayed);
	}

	GUI_DBG(("os_form_displayed: returning form_displayed:%d\n",
		form_displayed));
	return(form_displayed);
}

/******************************************************************************/

static void display_os_form()
{
	int		sts;

	GUI_DBG(("display_os_form()\n"));

	if (!os_form)
	{
		sts = FIf_new(OS_FORM, OS_FORM_FILE, RISgui_notification_routine,
			&os_form);
		if (sts)
		{
			RISgui_errhandle(RISUTL_E_CREATE_OS_FORM, sts);
			RISgui_report_error();
			GUI_DBG(("display_os_form:returning\n"));
			return;
		}
		RISgui_center_form(os_form);
	}

	if (!os_form_displayed())
	{
		sts = FIf_display(os_form);
		if (sts)
		{
			RISgui_errhandle(RISUTL_E_DISPLAY_OS_FORM, sts);
			RISgui_report_error();
			GUI_DBG(("display_os_form:returning\n"));
			return;
		}
	}

	FIfld_pos_cursor(os_form, OS_USERNAME_FIELD, 0, 0, 0, 0, 0, 0);
	CLEAR_ERROR;

	GUI_DBG(("display_os_form:returning\n"));
	return;
}

/******************************************************************************/

extern void erase_os_form()
{
	int	sts;

	GUI_DBG(("erase_os_form()\n"));

	if (os_form_displayed())
	{
		sts = FIf_erase(os_form);
		if (sts)
		{
			RISgui_errhandle(RISUTL_E_ERASE_OS_FORM, sts);
			RISgui_report_error();
			GUI_DBG(("erase_os_form: returning\n"));
			return;
		}
	}

	clear_username_field();
	clear_password_field();
	clear_osusername_field();
	clear_ospassword_field();

	CLEAR_ERROR;

	GUI_DBG(("erase_os_form: returning\n"));
	return;
}

/******************************************************************************/

static void process_accept_button()
{
	int sel_flag, r_pos;

	GUI_DBG(("process_accept_button()\n"));

	FIfld_get_text(os_form, OS_USERNAME_FIELD, 0, 0, RIS_MAX_ID_SIZE,
		(unsigned char *)username, &sel_flag, &r_pos);
	FIfld_get_text(os_form, OS_PASSWORD_FIELD, 0, 0, RIS_MAX_ID_SIZE,
		(unsigned char *)password, &sel_flag, &r_pos);

	FIfld_get_text(os_form, OS_OS_USERNAME_FIELD, 0, 0, RIS_MAX_ID_SIZE,
		(unsigned char *)osusername, &sel_flag, &r_pos);
	FIfld_get_text(os_form, OS_OS_PASSWORD_FIELD, 0, 0, RIS_MAX_ID_SIZE,
		(unsigned char *)ospassword, &sel_flag, &r_pos);

	erase_os_form();

	exit_status = 1;
	GUI_DBG(("process_accept_button:returning\n"));
}

/******************************************************************************/

static void process_cancel_button()
{
	GUI_DBG(("process_cancel_button()\n"));

	erase_os_form();

	exit_status = 0;
	GUI_DBG(("process_cancel_button:returning\n"));
}

/******************************************************************************/

static void process_toggle()
{
	GUI_DBG(("process_toggle()\n"));

	RISgui_set_passwd_echo(os_form, OS_PASSWORD_TOGGLE, OS_PASSWORD_FIELD);

	GUI_DBG(("process_toggle:returning\n"));
}

/******************************************************************************/

static void process_os_toggle()
{
	GUI_DBG(("process_os_toggle()\n"));

	RISgui_set_passwd_echo(os_form, OS_OS_PASSWORD_TOGGLE, OS_OS_PASSWORD_FIELD);

	GUI_DBG(("process_os_toggle:returning\n"));
}

/******************************************************************************/

extern void RISgui_process_os_form(
	int	g_label)
{
	int	i;
	static	ris_gui_label_function	process_gadget[] = 
	{
		{	FI_CANCEL,			process_cancel_button	},
		{	FI_ACCEPT,			process_accept_button	},
		{	OS_PASSWORD_TOGGLE,	process_toggle			},
		{	OS_OS_PASSWORD_TOGGLE,	process_os_toggle			},
	};
	static	int						process_gadget_count =
		sizeof(process_gadget)/sizeof(ris_gui_label_function);

	GUI_DBG(("RISgui_process_os_form(g_label:%d)\n", g_label));

	for (i = 0; i < process_gadget_count; i++)
	{
		if (process_gadget[i].label == g_label)
		{
			(process_gadget[i].function_ptr)();
			break;
		}
	}

	GUI_DBG(("RISgui_process_os_form:returning\n"));
}

/******************************************************************************/

extern int RISgui_get_os_username_password(
	char *uptr,
	char *pptr,
	char *osuptr,
	char *ospptr)
{
	GUI_DBG(("RISgui_get_os_username_password()\n"));

	exit_status = 0;

	display_os_form();

	RISgui_event_loop(os_form_displayed);

	if (exit_status)
	{
		strcpy(uptr, username);
		strcpy(pptr, password);
		strcpy(osuptr,osusername);
		strcpy(ospptr, ospassword);
	}

	GUI_DBG(("RISgui_get_os_username_password:returning exit_status:%d\n",
		exit_status));

	return exit_status;
}

/******************************************************************************/
