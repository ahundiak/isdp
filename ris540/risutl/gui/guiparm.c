/* Do not alter this SPC information: $Revision: 1.2.40.1 $ */
/*
**	NAME:							guiparm.c
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
#define guiparm_c
#include "fi.prt"
#include "event.prt"
#include "comdebug.prt"
#include "guierror.prt"
#include "guintfy.prt"
#include "guiparm.prt"
#include "guiin.prt"
#include "sys.prt"
#include "ris.prt"
#if defined(WIN32)
#include "fi_winnt.prt"
#endif

/*
**	VARIABLES
*/
static	Form	pa_form = 0;

/*
**	FUNCTIONS
*/

/******************************************************************************/

static void update_pa_form()
{
	char s[16];
	ris_parameters	p;

	GUI_DBG(("update_pa_form()\n"));

	RISget_parameters(&p);
	if (SQLCODE != RIS_SUCCESS)
	{
		RISgui_errhandle(RISUTL_E_RIS_ERROR, 0);
		RISgui_report_error();
		GUI_DBG(("update_pa_form:returning\n"));
		return;
	}

	sprintf(s, "0x%x", p.shared_memory);
	FIg_set_justification(pa_form, PA_SHARED_MEMORY_TEXT, FI_RIGHT_JUSTIFIED);
	FIg_set_text(pa_form, PA_SHARED_MEMORY_TEXT, s);

	sprintf(s, "% d", p.max_local_servers);
	FIg_set_justification(pa_form, PA_MAX_LOCAL_SERVERS_TEXT, FI_RIGHT_JUSTIFIED);
	FIg_set_text(pa_form, PA_MAX_LOCAL_SERVERS_TEXT, s);

	sprintf(s, "% d", p.max_rows);
	FIg_set_justification(pa_form, PA_MAX_ROWS_TEXT, FI_RIGHT_JUSTIFIED);
	FIg_set_text(pa_form, PA_MAX_ROWS_TEXT, s);

	sprintf(s, "% d", p.max_buffer_size);
	FIg_set_justification(pa_form, PA_MAX_BUFFER_SIZE_TEXT, FI_RIGHT_JUSTIFIED);
	FIg_set_text(pa_form, PA_MAX_BUFFER_SIZE_TEXT, s);

	sprintf(s, "%d", p.max_static_stmts);
	FIg_set_justification(pa_form, PA_MAX_STATIC_STMTS_TEXT, FI_RIGHT_JUSTIFIED);
	FIg_set_text(pa_form, PA_MAX_STATIC_STMTS_TEXT, s);

	sprintf(s, "%d", p.max_user_stmts);
	FIg_set_justification(pa_form, PA_USER_STMTS_TEXT, FI_RIGHT_JUSTIFIED);
	FIg_set_text(pa_form, PA_USER_STMTS_TEXT, s);

	sprintf(s, "%d", p.max_secondary_schemas);
	FIg_set_justification(pa_form, PA_SECONDARY_SCHEMAS_TEXT, FI_RIGHT_JUSTIFIED);
	FIg_set_text(pa_form, PA_SECONDARY_SCHEMAS_TEXT, s);

	sprintf(s, "%d", p.max_transactions);
	FIg_set_justification(pa_form, PA_TRANSACTIONS_TEXT, FI_RIGHT_JUSTIFIED);
	FIg_set_text(pa_form, PA_TRANSACTIONS_TEXT, s);

	sprintf(s, "%d", p.max_tables_in_memory);
	FIg_set_justification(pa_form, PA_TABLES_IN_MEM_TEXT, FI_RIGHT_JUSTIFIED);
	FIg_set_text(pa_form, PA_TABLES_IN_MEM_TEXT, s);

	sprintf(s, "%d", p.timestamp_interval);
	FIg_set_justification(pa_form, PA_TIMESTAMP_INTERVAL_TEXT, FI_RIGHT_JUSTIFIED);
	FIg_set_text(pa_form, PA_TIMESTAMP_INTERVAL_TEXT, s);

	sprintf(s, "%d", p.initial_timeout);
	FIg_set_justification(pa_form, PA_INITIAL_TIMEOUT_TEXT, FI_RIGHT_JUSTIFIED);
	FIg_set_text(pa_form, PA_INITIAL_TIMEOUT_TEXT, s);

	sprintf(s, "%d", p.timestamp_tolerance);
	FIg_set_justification(pa_form, PA_TIMESTAMP_TOLERANCE_TEXT, FI_RIGHT_JUSTIFIED);
	FIg_set_text(pa_form, PA_TIMESTAMP_TOLERANCE_TEXT, s);

	sprintf(s, "%d", p.buffer_full_size);
	FIg_set_justification(pa_form, PA_BUFFER_FULL_SIZE_TEXT, FI_RIGHT_JUSTIFIED);
	FIg_set_text(pa_form, PA_BUFFER_FULL_SIZE_TEXT, s);

	sprintf(s, "%d", p.buffer_full_timeout);
	FIg_set_justification(pa_form, PA_BUFFER_FULL_TIMEOUT_TEXT, FI_RIGHT_JUSTIFIED);
	FIg_set_text(pa_form, PA_BUFFER_FULL_TIMEOUT_TEXT, s);

	sprintf(s, "%d", p.lock_file_retry);
	FIg_set_justification(pa_form, PA_LOCK_FILE_RETRY_TEXT, FI_RIGHT_JUSTIFIED);
	FIg_set_text(pa_form, PA_LOCK_FILE_RETRY_TEXT, s);

	GUI_DBG(("update_pa_form:returning\n"));
}

/******************************************************************************/

static int pa_form_displayed()
{
	int	form_displayed = 0;

	GUI_DBG(("pa_form_displayed()\n"));

	if (pa_form)
	{
		FIf_is_displayed(pa_form, &form_displayed);
	}

	GUI_DBG(("pa_form_displayed: returning form_displayed:%d\n",
		form_displayed));
	return(form_displayed);
}

/******************************************************************************/

static void display_pa_form()
{
	int		sts;

	GUI_DBG(("display_pa_form()\n"));

	if (!pa_form)
	{
		sts = FIf_new(PA_FORM, PA_FORM_FILE, RISgui_notification_routine,
			&pa_form);
		if (sts)
		{
			RISgui_errhandle(RISUTL_E_CREATE_PA_FORM, sts);
			RISgui_report_error();
			GUI_DBG(("display_pa_form:returning\n"));
			return;
		}
		RISgui_center_form(pa_form);
	}

	if (!pa_form_displayed())
	{
		update_pa_form();

		sts = FIf_display(pa_form);
		if (sts)
		{
			RISgui_errhandle(RISUTL_E_DISPLAY_PA_FORM, sts);
			RISgui_report_error();
			GUI_DBG(("display_pa_form:returning\n"));
			return;
		}
	}

	CLEAR_ERROR;

	GUI_DBG(("display_pa_form:returning\n"));
	return;
}

/******************************************************************************/

extern void erase_pa_form()
{
	int	sts;

	GUI_DBG(("erase_pa_form()\n"));

	if (pa_form_displayed())
	{
		sts = FIf_erase(pa_form);
		if (sts)
		{
			RISgui_errhandle(RISUTL_E_ERASE_PA_FORM, sts);
			RISgui_report_error();
			GUI_DBG(("erase_pa_form: returning\n"));
			return;
		}
	}

	CLEAR_ERROR;

	GUI_DBG(("erase_pa_form: returning\n"));
	return;
}

/******************************************************************************/

extern void RISgui_process_pa_form(
	int	g_label)
{
	switch(g_label)
	{
		case FI_CANCEL:
			erase_pa_form();
			break;
	}
	GUI_DBG(("RISgui_process_pa_form:returning\n"));
}

/******************************************************************************/

extern void RISgui_show_parameters(
	void)
{
	GUI_DBG(("RISgui_show_parameters()\n"));

	display_pa_form();

	RISgui_event_loop(pa_form_displayed);

	GUI_DBG(("RISgui_show_parameters:returning\n"));
}

/******************************************************************************/
