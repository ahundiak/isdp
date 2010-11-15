/* Do not alter this SPC information: $Revision: 1.2.40.1 $ */
/*
**	NAME:							frmpswd.c
**	AUTHORS:						Terrence McIntyre
**	CREATION DATE:					5/93
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
#define frmpswd_c
#include "fi.prt"
#include "event.prt"
#include "comdebug.prt"
#include "frmerror.prt"
#include "frmntfy.prt"
#include "frmpswd.prt"
#include "frmutil.prt"
#include "sys.prt"
#if defined (WIN32)
#include "fi_winnt.prt"
#endif

/*
**	VARIABLES
*/
static	 Form	pw_form = 0;
static	 int		exit_status;
static	 char	password[RIS_MAX_ID_SIZE];

/*
**	FUNCTIONS
*/

/******************************************************************************/

static void clear_password_field()
{
	FRM_DBG(("clear_password_field()\n"));

	FIfld_set_text(pw_form, PW_PASSWORD_FIELD, 0, 0, "", 0);

	FRM_DBG(("clear_password_field:returning\n"));
}

/******************************************************************************/

static int pw_form_displayed()
{
	int	form_displayed = 0;

	FRM_DBG(("pw_form_displayed()\n"));

	if (pw_form)
	{
		FIf_is_displayed(pw_form, &form_displayed);
	}

	FRM_DBG(("pw_form_displayed: returning form_displayed:%d\n",
		form_displayed));
	return(form_displayed);
}

/******************************************************************************/

static void display_pw_form()
{
	int		sts;

	FRM_DBG(("display_pw_form()\n"));

	if (!pw_form)
	{
		sts = FIf_new(PW_FORM, PW_FORM_FILE, RISfrm_notification_routine,
			&pw_form);
		if (sts)
		{
			RISfrm_form_errhandle(RISUTL_E_CREATE_PW_FORM, sts);
			RISfrm_report_error();
			FRM_DBG(("display_pw_form:returning\n"));
			return;
		}
	}

	if (!pw_form_displayed())
	{
		sts = FIf_display(pw_form);
		if (sts)
		{
			RISfrm_form_errhandle(RISUTL_E_DISPLAY_PW_FORM, sts);
			RISfrm_report_error();
			FRM_DBG(("display_pw_form:returning\n"));
			return;
		}
	}

	FIfld_pos_cursor(pw_form, PW_PASSWORD_FIELD, 0, 0, 0, 0, 0, 0);
	CLEAR_ERROR;

	FRM_DBG(("display_pw_form:returning\n"));
	return;
}

/******************************************************************************/

extern void erase_pw_form()
{
	int	sts;

	FRM_DBG(("erase_pw_form()\n"));

	if (pw_form_displayed())
	{
		sts = FIf_erase(pw_form);
		if (sts)
		{
			RISfrm_form_errhandle(RISUTL_E_ERASE_PW_FORM, sts);
			RISfrm_report_error();
			FRM_DBG(("erase_pw_form: returning\n"));
			return;
		}
	}

	clear_password_field();

	CLEAR_ERROR;

	FRM_DBG(("erase_pw_form: returning\n"));
	return;
}

/******************************************************************************/

static void process_accept_button()
{
	int sel_flag, r_pos;

	FRM_DBG(("process_accept_button()\n"));

	FIfld_get_text(pw_form, PW_PASSWORD_FIELD, 0, 0, RIS_MAX_ID_SIZE,
		(unsigned char *)password, &sel_flag, &r_pos);

	erase_pw_form();

	exit_status = 1;
	FRM_DBG(("process_accept_button:returning\n"));
}

/******************************************************************************/

static void process_cancel_button()
{
	FRM_DBG(("process_cancel_button()\n"));

	erase_pw_form();

	exit_status = 0;
	FRM_DBG(("process_cancel_button:returning\n"));
}

/******************************************************************************/

static void process_toggle()
{
	FRM_DBG(("process_toggle()\n"));

	RISfrm_set_passwd_echo(pw_form, PW_PASSWORD_TOGGLE, PW_PASSWORD_FIELD);

	FRM_DBG(("process_toggle:returning\n"));
}

/******************************************************************************/

extern void RISfrm_process_pw_form(
	int	g_label)
{
	int	i;
	static	RISfrm_label_function	process_gadget[] = 
	{
		{	FI_CANCEL,			process_cancel_button	},
		{	FI_ACCEPT,			process_accept_button	},
		{	PW_PASSWORD_TOGGLE,	process_toggle			},
	};
	static	int						process_gadget_count =
		sizeof(process_gadget)/sizeof(RISfrm_label_function);

	FRM_DBG(("RISfrm_process_pw_form(g_label:%d)\n", g_label));

	for (i = 0; i < process_gadget_count; i++)
	{
		if (process_gadget[i].label == g_label)
		{
			(process_gadget[i].function_ptr)();
			break;
		}
	}

	FRM_DBG(("RISfrm_process_pw_form:returning\n"));
}

/******************************************************************************/

extern int RISfrm_get_password(
	char *ptr)
{
	FRM_DBG(("RISfrm_get_password()\n"));

	exit_status = 0;

	display_pw_form();

	RISfrm_event_loop(pw_form_displayed);

	if (exit_status)
	{
		strcpy(ptr, password);
	}

	FRM_DBG(("RISfrm_get_password:returning exit_status:%d\n",
		exit_status));

	return exit_status;
}

/******************************************************************************/
