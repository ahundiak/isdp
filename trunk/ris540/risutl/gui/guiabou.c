/* Do not alter this SPC information: $Revision: 1.5.3.1 $ */
/*
**	NAME:							guiabou.c
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
#include "risver.h"

/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define guiabou_c
#include "fi.prt"
#include "event.prt"
#include "comdebug.prt"
#include "comumsg.prt"
#include "guierror.prt"
#include "guintfy.prt"
#include "guiabou.prt"
#include "guiin.prt"
#include "sys.prt"
#if defined(WIN32)
#include "fi_winnt.prt"
#endif
/*
**	VARIABLES
*/
static	Form	ab_form = 0;

/*
**	FUNCTIONS
*/

/******************************************************************************/

static void update_ab_form()
{
	char s[255];
	GUI_DBG(("update_ab_form()\n"));

	sprintf(s, MSG(RISUTL_I_REL_INT_SYS), RIS_version);
	FIg_set_text(ab_form, AB_TEXT_1, s);

	/*sprintf(s, MSG(RISUTL_I_COPYRIGHT));*/
	/* 1996.03.12:Alan Barksdale:TR439600483 */
	strcpy(s, MSG(RISUTL_I_BEGIN_COPYRIGHT));
	strcat(s, " ");
	strcat(s, COPYRIGHTYEAR);
	strcat(s, ", ");
	strcat(s, MSG(RISUTL_I_END_COPYRIGHT));
	FIg_set_text(ab_form, AB_TEXT_2, s);

	GUI_DBG(("update_ab_form:returning\n"));
}

/******************************************************************************/

static int ab_form_displayed()
{
	int	form_displayed = 0;

	GUI_DBG(("ab_form_displayed()\n"));

	if (ab_form)
	{
		FIf_is_displayed(ab_form, &form_displayed);
	}

	GUI_DBG(("ab_form_displayed: returning form_displayed:%d\n",
		form_displayed));
	return(form_displayed);
}

/******************************************************************************/

static void display_ab_form()
{
	int		sts;

	GUI_DBG(("display_ab_form()\n"));

	if (!ab_form)
	{
		sts = FIf_new(AB_FORM, AB_FORM_FILE, RISgui_notification_routine,
			&ab_form);
		if (sts)
		{
			RISgui_errhandle(RISUTL_E_CREATE_AB_FORM, sts);
			RISgui_report_error();
			GUI_DBG(("display_ab_form:returning\n"));
			return;
		}
		RISgui_center_form(ab_form);
	}

	if (!ab_form_displayed())
	{
		update_ab_form();

		sts = FIf_display(ab_form);
		if (sts)
		{
			RISgui_errhandle(RISUTL_E_DISPLAY_AB_FORM, sts);
			RISgui_report_error();
			GUI_DBG(("display_ab_form:returning\n"));
			return;
		}
	}

	CLEAR_ERROR;

	GUI_DBG(("display_ab_form:returning\n"));
	return;
}

/******************************************************************************/

extern void erase_ab_form()
{
	int	sts;

	GUI_DBG(("erase_ab_form()\n"));

	if (ab_form_displayed())
	{
		sts = FIf_erase(ab_form);
		if (sts)
		{
			RISgui_errhandle(RISUTL_E_ERASE_AB_FORM, sts);
			RISgui_report_error();
			GUI_DBG(("erase_ab_form: returning\n"));
			return;
		}
	}

	CLEAR_ERROR;

	GUI_DBG(("erase_ab_form: returning\n"));
	return;
}

/******************************************************************************/

extern void RISgui_process_ab_form(
	int	g_label)
{
	switch(g_label)
	{
		case FI_CANCEL:
			erase_ab_form();
			break;
	}
	GUI_DBG(("RISgui_process_ab_form:returning\n"));
}

/******************************************************************************/

extern void RISgui_show_about(
	void)
{
	GUI_DBG(("RISgui_show_parameters()\n"));

	display_ab_form();

	RISgui_event_loop(ab_form_displayed);

	GUI_DBG(("RISgui_show_parameters:returning\n"));
}

/******************************************************************************/
