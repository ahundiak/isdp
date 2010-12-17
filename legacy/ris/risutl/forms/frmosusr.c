/* Do not alter this SPC information: $Revision: 1.2.40.1 $ */
/*
**	NAME:							frmosusr.c
**	AUTHORS:						linda wang
**	CREATION DATE:					4/94
**	ABSTRACT:
**	
**	REVISION HISTORY:
**
**	11/94:	Added support for INTERNATIONALIZATION.  Linda Wang
**	02/03/95 Removed NTJ specific changes. rlk
*/
 
/*
**	INCLUDES
*/
#include "rislimit.h"
#include "forms.h"

/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define frmosusr_c
#include "fi.prt"
#include "event.prt"
#include "comdebug.prt"
#include "frmerror.prt"
#include "frmosusr.prt"
#include "frmntfy.prt"
#include "frmutil.prt"
#include "sys.prt"
#if defined (WIN32)
#include "fi_winnt.prt"
#endif

/*
**	VARIABLES
*/
static	 Form	os_form = 0;
static	 int		exit_status;
static	 char	username[RIS_MAX_ID_SIZE];
static	 char	password[RIS_MAX_ID_SIZE];
static	 char	os_username[RIS_MAX_ID_SIZE];
static	 char	os_password[RIS_MAX_ID_SIZE];

/*
**	FUNCTIONS
*/

/******************************************************************************/

static void clear_username_field()
{
	FRM_DBG(("clear_username_field()\n"));

	FIfld_set_text(os_form, OS_USERNAME_FIELD, 0, 0, "", 0);

	FRM_DBG(("clear_username_field:returning\n"));
}

/******************************************************************************/

static void clear_password_field()
{
	FRM_DBG(("clear_password_field()\n"));

	FIfld_set_text(os_form, OS_PASSWORD_FIELD, 0, 0, "", 0);

	FRM_DBG(("clear_password_field:returning\n"));
}

/******************************************************************************/

static void clear_os_username_field()
{
	FRM_DBG(("clear_os_username_field()\n"));

	FIfld_set_text(os_form, OS_OS_USERNAME_FIELD, 0, 0, "", 0);

	FRM_DBG(("clear_os_username_field:returning\n"));
}

/******************************************************************************/

static void clear_os_password_field()
{
	FRM_DBG(("clear_os_password_field()\n"));

	FIfld_set_text(os_form, OS_OS_PASSWORD_FIELD, 0, 0, "", 0);

	FRM_DBG(("clear_os_password_field:returning\n"));
}

/******************************************************************************/

static int os_form_displayed()
{
	int	form_displayed = 0;

	FRM_DBG(("os_form_displayed()\n"));

	if (os_form)
	{
		FIf_is_displayed(os_form, &form_displayed);
	}

	FRM_DBG(("os_form_displayed: returning form_displayed:%d\n",
		form_displayed));
	return(form_displayed);
}

/******************************************************************************/

static void display_os_form()
{
	int		sts;

	FRM_DBG(("display_os_form()\n"));

	if (!os_form)
	{
		sts = FIf_new(OS_FORM, OS_FORM_FILE, RISfrm_notification_routine,
			&os_form);
		if (sts)
		{
			RISfrm_form_errhandle(RISUTL_E_CREATE_OS_FORM, sts);
			RISfrm_report_error();
			FRM_DBG(("display_os_form:returning\n"));
			return;
		}
	}

	if (!os_form_displayed())
	{
		sts = FIf_display(os_form);
		if (sts)
		{
			RISfrm_form_errhandle(RISUTL_E_DISPLAY_OS_FORM, sts);
			RISfrm_report_error();
			FRM_DBG(("display_os_form:returning\n"));
			return;
		}
	}

	FIfld_pos_cursor(os_form, OS_USERNAME_FIELD, 0, 0, 0, 0, 0, 0);
	CLEAR_ERROR;

	FRM_DBG(("display_os_form:returning\n"));
	return;
}

/******************************************************************************/

extern void erase_os_form()
{
	int	sts;

	FRM_DBG(("erase_os_form()\n"));

	if (os_form_displayed())
	{
		sts = FIf_erase(os_form);
		if (sts)
		{
			RISfrm_form_errhandle(RISUTL_E_ERASE_OS_FORM, sts);
			RISfrm_report_error();
			FRM_DBG(("erase_os_form: returning\n"));
			return;
		}
	}

	clear_username_field();
	clear_password_field();
	clear_os_username_field();
	clear_os_password_field();

	CLEAR_ERROR;

	FRM_DBG(("erase_os_form: returning\n"));
	return;
}

/******************************************************************************/

static void process_accept_button()
{
	int sel_flag, r_pos;

	FRM_DBG(("process_accept_button()\n"));

	FIfld_get_text(os_form, OS_USERNAME_FIELD, 0, 0, RIS_MAX_ID_SIZE,
		(unsigned char *)username, &sel_flag, &r_pos);
	FIfld_get_text(os_form, OS_PASSWORD_FIELD, 0, 0, RIS_MAX_ID_SIZE,
		(unsigned char *)password, &sel_flag, &r_pos);
	FIfld_get_text(os_form, OS_OS_USERNAME_FIELD, 0, 0, RIS_MAX_ID_SIZE,
		(unsigned char *)os_username, &sel_flag, &r_pos);
	FIfld_get_text(os_form, OS_OS_PASSWORD_FIELD, 0, 0, RIS_MAX_ID_SIZE,
		(unsigned char *)os_password, &sel_flag, &r_pos);

	erase_os_form();

	exit_status = 1;
	FRM_DBG(("process_accept_button:returning\n"));
}

/******************************************************************************/

static void process_cancel_button()
{
	FRM_DBG(("process_cancel_button()\n"));

	erase_os_form();

	exit_status = 0;
	FRM_DBG(("process_cancel_button:returning\n"));
}

/******************************************************************************/

static void process_toggle()
{
	FRM_DBG(("process_toggle()\n"));

	RISfrm_set_passwd_echo(os_form, OS_PASSWORD_TOGGLE, OS_PASSWORD_FIELD);

	FRM_DBG(("process_toggle:returning\n"));
}

/******************************************************************************/

static void process_os_toggle()
{
	FRM_DBG(("process_os_toggle()\n"));

	RISfrm_set_passwd_echo(os_form, OS_OS_PASSWORD_TOGGLE, OS_OS_PASSWORD_FIELD);

	FRM_DBG(("process_toggle:returning\n"));
}

/******************************************************************************/

extern void RISfrm_process_os_form(
	int	g_label)
{
	int	i;
	static	RISfrm_label_function	process_gadget[] = 
	{
		{	FI_CANCEL,			process_cancel_button	},
		{	FI_ACCEPT,			process_accept_button	},
		{	OS_PASSWORD_TOGGLE,	process_toggle			},
		{	OS_OS_PASSWORD_TOGGLE,	process_os_toggle			},
	};
	static	int						process_gadget_count =
		sizeof(process_gadget)/sizeof(RISfrm_label_function);

	FRM_DBG(("RISfrm_process_os_form(g_label:%d)\n", g_label));

	for (i = 0; i < process_gadget_count; i++)
	{
		if (process_gadget[i].label == g_label)
		{
			(process_gadget[i].function_ptr)();
			break;
		}
	}

	FRM_DBG(("RISfrm_process_os_form:returning\n"));
}

/******************************************************************************/

extern int RISfrm_get_os_username_password(
	char *uptr,
	char *pptr,
	char *osuptr,
	char *ospptr)
{
	FRM_DBG(("RISfrm_get_os_username_password()\n"));

	exit_status = 0;

	display_os_form();

	RISfrm_event_loop(os_form_displayed);

	if (exit_status)
	{
		strcpy(uptr, username);
		strcpy(pptr, password);
		strcpy(osuptr, os_username);
		strcpy(ospptr, os_password);
	}

	FRM_DBG(("RISfrm_get_os_username_password:returning exit_status:%d\n",
		exit_status));

	return exit_status;
}

/******************************************************************************/
