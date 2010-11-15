/* Do not alter this SPC information: $Revision: 1.2.40.1 $ */
/*
**	NAME:							guishow.c
**	AUTHORS:						Terrence McIntyre
**	CREATION DATE:					7/93
**	ABSTRACT:
**	
**	REVISION HISTORY:
**
**	11/94:	Added support for INTERNATIONALIZATION.  Rick Kramer
*/
 
/*
**	INCLUDES
*/
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
#define guishow_c
#include "fi.prt"
#include "comdebug.prt"
#include "guiabou.prt"
#include "guierror.prt"
#include "guintfy.prt"
#include "guiparm.prt"
#include "guishow.prt"
#include "guishtr.prt"
#include "guiin.prt"
#include "sys.prt"
#if defined(WIN32)
#include "fi_winnt.prt"
#endif

/*
**	VARIABLES
*/
static	Form	sh_form = 0;

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern int RISgui_sh_form_displayed()
{
	int	form_displayed = 0;

	GUI_DBG(("RISgui_sh_form_displayed()\n"));

	if (sh_form)
	{
		FIf_is_displayed(sh_form, &form_displayed);
	}

	GUI_DBG(("RISgui_sh_form_displayed: returning form_displayed:%d\n",
		form_displayed));
	return(form_displayed);
}

/******************************************************************************/

extern void RISgui_display_sh_form(
	void)
{
	int		sts;

	GUI_DBG(("RISgui_display_sh_form()\n"));

	if (!sh_form)
	{
		sts = FIf_new(SH_FORM, SH_FORM_FILE, RISgui_notification_routine,
			&sh_form);
		if (sts)
		{
			RISgui_errhandle(RISUTL_E_CREATE_SH_FORM, sts);
			RISgui_report_error();
			GUI_DBG(("RISgui_display_sh_form:returning\n"));
			return;
		}

		RISgui_center_form(sh_form);
	}

	if (!RISgui_sh_form_displayed())
	{
		sts = FIf_display(sh_form);
		if (sts)
		{
			RISgui_errhandle(RISUTL_E_DISPLAY_SH_FORM, sts);
			RISgui_report_error();
			GUI_DBG(("display_sh_form:returning\n"));
			return;
		}
	}

	CLEAR_ERROR;

	GUI_DBG(("RISgui_display_sh_form:returning\n"));
	return;
}

/******************************************************************************/

extern void RISgui_erase_sh_form()
{
	int	sts;

	GUI_DBG(("RISgui_erase_sh_form()\n"));

	if (RISgui_sh_form_displayed())
	{
		sts = FIf_erase(sh_form);
		if (sts)
		{
			RISgui_errhandle(RISUTL_E_ERASE_SH_FORM, sts);
			RISgui_report_error();
			GUI_DBG(("RISgui_erase_sh_form: returning\n"));
			return;
		}
	}

	CLEAR_ERROR;

	GUI_DBG(("RISgui_erase_sh_form: returning\n"));
	return;
}

/******************************************************************************/

extern void RISgui_process_sh_form(
	int	g_label)
{
	GUI_DBG(("RISgui_process_sh_form(g_label:%d)\n", g_label));

	RISgui_erase_sh_form();

	switch(g_label)
	{
		case SH_PARAMETERS_BUTTON:
			RISgui_show_parameters();
			break;

		case SH_ABOUT_BUTTON:
			RISgui_show_about();
			break;

		case SH_TRANSACTIONS_BUTTON:
			RISgui_show_transactions();
			break;
	}

	GUI_DBG(("RISgui_process_sh_form:returning\n"));
}

/******************************************************************************/
