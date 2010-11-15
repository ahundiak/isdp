/* Do not alter this SPC information: $Revision: 1.3.19.1 $ */
/*
**	NAME:							guiutls.c
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
#define guiutls_c
#include "fi.prt"
#include "comdebug.prt"
#include "guierror.prt"
#include "guintfy.prt"
#include "guiutls.prt"
#include "guiin.prt"
#include "event.prt"
#include "sys.prt"
#include "ris.prt"
#if defined(WIN32)
#include "fi_winnt.prt"
#endif

/*
**	VARIABLES
*/
static	Form	ut_form = 0;

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern int RISgui_ut_form_displayed()
{
	int	form_displayed = 0;

	GUI_DBG(("RISgui_ut_form_displayed()\n"));

	if (ut_form)
	{
		FIf_is_displayed(ut_form, &form_displayed);
	}

	GUI_DBG(("RISgui_ut_form_displayed: returning form_displayed:%d\n",
		form_displayed));
	return(form_displayed);
}

/******************************************************************************/

extern void RISgui_display_ut_form(
	void)
{
	int		sts;

	GUI_DBG(("RISgui_display_ut_form()\n"));

	if (!ut_form)
	{
		sts = FIf_new(UT_FORM, UT_FORM_FILE, RISgui_notification_routine,
			&ut_form);
		if (sts)
		{
			RISgui_errhandle(RISUTL_E_CREATE_UT_FORM, sts);
			RISgui_report_error();
			GUI_DBG(("RISgui_display_ut_form:returning\n"));
			return;
		}
#if defined(WIN32)
	if (RISget_platform() == IS_CHICAGO)
	{
		FIg_disable(ut_form, UT_LOADER_BUTTON);
		FIg_disable(ut_form, UT_UNLOADER_BUTTON);
		FIg_disable(ut_form, UT_RECORD_BUTTON);
		FIg_disable(ut_form, UT_PLAYBACK_BUTTON);
		FIg_disable(ut_form, UT_CLEAN_SERVER_BUTTON);
		FIg_disable(ut_form, UT_DECODE_BUTTON);
		FIg_disable(ut_form, UT_DATA_TYPES_BUTTON);
	}
#endif
		RISgui_center_form(ut_form);
	}

	if (!RISgui_ut_form_displayed())
	{
		sts = FIf_display(ut_form);
		if (sts)
		{
			RISgui_errhandle(RISUTL_E_DISPLAY_UT_FORM, sts);
			RISgui_report_error();
			GUI_DBG(("display_ut_form:returning\n"));
			return;
		}
	}

	CLEAR_ERROR;

	GUI_DBG(("RISgui_display_ut_form:returning\n"));
	return;
}

/******************************************************************************/

extern void RISgui_erase_ut_form()
{
	int	sts;

	GUI_DBG(("RISgui_erase_ut_form()\n"));

	if (RISgui_ut_form_displayed())
	{
		sts = FIf_erase(ut_form);
		if (sts)
		{
			RISgui_errhandle(RISUTL_E_ERASE_UT_FORM, sts);
			RISgui_report_error();
			GUI_DBG(("RISgui_erase_ut_form: returning\n"));
			return;
		}
	}

	CLEAR_ERROR;

	GUI_DBG(("RISgui_erase_ut_form: returning\n"));
	return;
}

/******************************************************************************/

extern void RISgui_process_ut_form(
	int	g_label)
{
	GUI_DBG(("RISgui_process_ut_form(g_label:%d)\n", g_label));

	RISgui_erase_ut_form();

	switch(g_label)
	{
		case UT_RIS_BUTTON:
			RISgui_start_ris();
			break;
		case UT_SCHEMA_MANAGER_BUTTON:
			RISgui_start_rismgr();
			break;
		case UT_LOADER_BUTTON:
			RISgui_start_rislod();
			break;
		case UT_UNLOADER_BUTTON:
			RISgui_start_risunlod();
			break;
		case UT_RECORD_BUTTON:
			RISgui_start_risrecrd();
			break;
		case UT_PLAYBACK_BUTTON:
			RISgui_start_risplbck();
			break;
		case UT_CLEAN_SERVER_BUTTON:
			RISgui_start_risclnsr();
			break;
		case UT_DECODE_BUTTON:
			RISgui_start_risdcode();
			break;
		case UT_DATA_TYPES_BUTTON:
			RISgui_start_risdtype();
			break;
	}

	GUI_DBG(("RISgui_process_ut_form:returning\n"));
}

/******************************************************************************/
