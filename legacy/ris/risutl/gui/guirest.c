/* Do not alter this SPC information: $Revision: 1.2.40.1 $ */
/*
**	NAME:							guirest.c
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
#define guirest_c
#include "fi.prt"
#include "event.prt"
#include "comdebug.prt"
#include "guierror.prt"
#include "guintfy.prt"
#include "guirest.prt"
#include "guiin.prt"
#include "sys.prt"
#if defined(WIN32)
#include "fi_winnt.prt"
#endif

/*
**	VARIABLES
*/
static	Form	rs_form = 0;
static	int		exit_status = 0;

/*
**	FUNCTIONS
*/

/******************************************************************************/

static int rs_form_displayed()
{
	int	form_displayed = 0;

	GUI_DBG(("rs_form_displayed()\n"));

	if (rs_form)
	{
		FIf_is_displayed(rs_form, &form_displayed);
	}

	GUI_DBG(("rs_form_displayed: returning form_displayed:%d\n",
		form_displayed));
	return(form_displayed);
}

/******************************************************************************/

static void display_rs_form()
{
	int		sts;

	GUI_DBG(("display_rs_form()\n"));

	if (!rs_form)
	{
		sts = FIf_new(RS_FORM, RS_FORM_FILE, RISgui_notification_routine,
			&rs_form);
		if (sts)
		{
			RISgui_errhandle(RISUTL_E_CREATE_RS_FORM, sts);
			RISgui_report_error();
			GUI_DBG(("display_rs_form:returning\n"));
			return;
		}
		RISgui_center_form(rs_form);
	}

	if (!rs_form_displayed())
	{
		sts = FIf_display(rs_form);
		if (sts)
		{
			RISgui_errhandle(RISUTL_E_DISPLAY_RS_FORM, sts);
			RISgui_report_error();
			GUI_DBG(("display_rs_form:returning\n"));
			return;
		}
	}

	CLEAR_ERROR;

	GUI_DBG(("display_rs_form:returning\n"));
	return;
}

/******************************************************************************/

extern void erase_rs_form()
{
	int	sts;

	GUI_DBG(("erase_rs_form()\n"));

	if (rs_form_displayed())
	{
		sts = FIf_erase(rs_form);
		if (sts)
		{
			RISgui_errhandle(RISUTL_E_ERASE_RS_FORM, sts);
			RISgui_report_error();
			GUI_DBG(("erase_rs_form: returning\n"));
			return;
		}
	}

	CLEAR_ERROR;

	GUI_DBG(("erase_rs_form: returning\n"));
	return;
}

/******************************************************************************/

extern void RISgui_process_rs_form(
	int	g_label)
{
	GUI_DBG(("RISgui_process_rs_form(g_label:%d)\n", g_label));

	erase_rs_form();

	switch (g_label)
	{
		case FI_ACCEPT:
			exit_status = 1;
			break;

		case FI_CANCEL:
		default:
			exit_status = 0;
			break;
	}

	GUI_DBG(("RISgui_process_rs_form:returning\n"));
}

/******************************************************************************/

extern int RISgui_restart(
	void)
{
	GUI_DBG(("RISgui_restart()\n"));

	exit_status = 0;

	display_rs_form();

	RISgui_event_loop(rs_form_displayed);

	GUI_DBG(("RISgui_restart:returning exit_status:%d\n",
		exit_status));
	return exit_status;
}

/******************************************************************************/
