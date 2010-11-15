/* Do not alter this SPC information: $Revision: 1.3.27.1 $ */
/*
**	NAME:							guicfrm.c
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
#define guicfrm_c
#include "fi.prt"
#include "event.prt"
#include "comdebug.prt"
#include "guierror.prt"
#include "guintfy.prt"
#include "guicfrm.prt"
#include "guiin.prt"
#include "sys.prt"
#if defined(WIN32)
#include "fi_winnt.prt"
#endif

/*
**	VARIABLES
*/
static	Form	cf_form = 0;
static	int		exit_status;

/*
**	FUNCTIONS
*/

/******************************************************************************/

#if defined(unix)
static int cf_form_displayed()
{
	int	form_displayed = 0;

	GUI_DBG(("cf_form_displayed()\n"));

	if (cf_form)
	{
		FIf_is_displayed(cf_form, &form_displayed);
	}

	GUI_DBG(("cf_form_displayed: returning form_displayed:%d\n",
		form_displayed));
	return(form_displayed);
}
#endif

/******************************************************************************/

#if defined(unix)
static void display_cf_form(
	const char *text)
{
	int		sts;

	GUI_DBG(("display_cf_form(text:<%s>)\n", STRING(text)));

	if (!cf_form)
	{
		sts = FIf_new(CF_FORM, CF_FORM_FILE, RISgui_notification_routine,
			&cf_form);
		if (sts)
		{
			RISgui_errhandle(RISUTL_E_CREATE_CF_FORM, sts);
			RISgui_report_error();
			GUI_DBG(("display_cf_form:returning\n"));
			return;
		}
		RISgui_center_form(cf_form);
	}

	if (!cf_form_displayed())
	{
		if (text)
		{
			FIg_set_text(cf_form, CF_MESSAGE_TEXT, (char *)text);
		}
		else
		{
			FIg_set_text(cf_form, CF_MESSAGE_TEXT, "");
		}

		sts = FIf_display(cf_form);
		if (sts)
		{
			RISgui_errhandle(RISUTL_E_DISPLAY_CF_FORM, sts);
			RISgui_report_error();
			GUI_DBG(("display_cf_form:returning\n"));
			return;
		}
	}

	CLEAR_ERROR;

	GUI_DBG(("display_cf_form:returning\n"));
	return;
}
#endif

/******************************************************************************/

#if defined(unix)
extern void erase_cf_form()
{
	int	sts;

	GUI_DBG(("erase_cf_form()\n"));

	if (cf_form_displayed())
	{
		sts = FIf_erase(cf_form);
		if (sts)
		{
			RISgui_errhandle(RISUTL_E_ERASE_CF_FORM, sts);
			RISgui_report_error();
			GUI_DBG(("erase_cf_form: returning\n"));
			return;
		}
	}

	CLEAR_ERROR;

	GUI_DBG(("erase_cf_form: returning\n"));
	return;
}
#endif

/******************************************************************************/

#if defined(unix)
extern void RISgui_process_cf_form(
	int	g_label)
{
	GUI_DBG(("RISgui_process_cf_form(g_label:%d)\n", g_label));

	erase_cf_form();

	switch (g_label)
	{
		case CF_YES_BUTTON:
		case FI_ACCEPT:
			exit_status = 1;
			break;

		case CF_NO_BUTTON:
		case FI_CANCEL:
		default:
			exit_status = 0;
			break;
	}

	GUI_DBG(("RISgui_process_cf_form:returning\n"));
}
#endif

/******************************************************************************/

extern int RISgui_confirm(
	const char *text)
{
	GUI_DBG(("RISgui_confirm(text:<%s>)\n", STRING(text)));

	exit_status = 0;
#if defined(unix)

	display_cf_form(text);

	RISgui_event_loop(cf_form_displayed);

#elif defined(WIN32)

	switch(MessageBox(RISgui_get_in_handle(), text, "Confirm", 
		MB_ICONEXCLAMATION|MB_YESNO))
	{
		case IDYES:
			exit_status = 1;
			break;

		case 0:
			RISgui_errhandle(RISUTL_E_DISPLAY_CF_FORM, 0);
			RISgui_report_error();
			break;

		case IDNO:
		default:
			break;

	}
#else
ERROR NO CODE
#endif

	GUI_DBG(("RISgui_confirm:returning exit_status:%d\n",
		exit_status));
	return exit_status;
}

/******************************************************************************/
